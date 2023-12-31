/*
    Copyright (C) 2018-2019 VMware, Inc.
    SPDX-License-Identifier: GPL-2.0
    Linux kernel module to dump process page-tables.
    The kernel-module is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public
    License as published by the Free Software Foundation; version 2.
    The kernel-module  is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    General Public License for more details.
    You should find a copy of v2 of the GNU General Public License somewhere
    on your Linux system; if not, write to the Free Software Foundation,
    Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/

#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/fs.h>
#include <linux/proc_fs.h>
#include <linux/pid.h>
#include <linux/sched.h>
#include <asm/pgtable.h>

#include <linux/version.h>
#include <linux/debugfs.h>
#include <linux/kasan.h>
#include <linux/mm.h>
#include <linux/seq_file.h>
#include <linux/highmem.h>
#include <linux/spinlock.h>
#include <asm/pgtable.h>
#include <linux/fdtable.h>
#include <linux/kvm_host.h>
#include <linux/sched/mm.h>
#include <asm/uaccess.h>

#include <page-table-dump.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("VMWare Inc");
MODULE_DESCRIPTION("A page-table dumper for processes");
MODULE_VERSION("1.00");


#define CONFIG_DEVICE_NAME "ptdump"

#define CONFIG_DEBUG 1

#define CONFIG_X86_64 1

/* In linux VA space is divided in half, 47 bits for user, 47 bits for kernel */
#define CONFIG_KERNEL_SPACE_START 256

#ifndef pgtable_l5_enabled
#define pgtable_l5_enabled 0
#endif

#define OPT_PRINT_TAGS 1
#define OPT_PRINT_ENTRIES 1
#define OPT_PRINT_EMPTY_ENTRIES 0

#define OPT_DUMP_L4 1
#define OPT_DUMP_L3 1
#define OPT_DUMP_L2 1    
#define OPT_DUMP_L1 1


#define IDENT_L4 "  "
#define IDENT_L3 "    "
#define IDENT_L2 "      "
#define IDENT_L1 "        "

#define BASE_PAGE_SIZE  (4 << 10)   //4k
#define LARGE_PAGE_SIZE (2UL << 20)  //s
#define HUGE_PAGE_SIZE (1UL << 30)
#define SUPER_PAGE_SIZE (512UL << 30)

#define  VA(l4,l3,l2,l1) ((l1) * BASE_PAGE_SIZE \
		+ (l2) * LARGE_PAGE_SIZE \
		+ (l3) * HUGE_PAGE_SIZE \
		+ (l4) * SUPER_PAGE_SIZE)

unsigned pgtables_type = 0;
struct mm_struct *mm = NULL;
struct kvm *kvm = NULL;

// stores the proc fs file information
static struct proc_dir_entry *ptdump_proc;

#define X86_64_PAGING_ENTRY_SIZE 64
#define FLAG_BITS 12
#define LARGE_FLAGE_BITS 21
#define HUGE_FLAGE_BITS 30


#define TABLEADDR(_type, _pa)

#if LINUX_VERSION_CODE < KERNEL_VERSION(5,0,0)
#define memory_user_accessible(_addr, _size) access_ok(VERIFY_WRITE, _addr, _size)
#else
#define memory_user_accessible(_addr, _size) access_ok(_addr, _size)
#endif

#if LINUX_VERSION_CODE < KERNEL_VERSION(4,20,0)
#define KVM_VCPU_MMU_ROOT	(vcpu->arch.mmu.root_hpa)
#else
#define KVM_VCPU_MMU_ROOT	(vcpu->arch.mmu->root_hpa)
#endif

// /*
//  * ============================================================================
//  * x86_64 Page-Table Layout
//  * ============================================================================
//  */
// union ptable_entry {
// 	uint64_t raw;
// 	struct {
// 		uint64_t        present         :1;
// 		uint64_t        read_write      :1;
// 		uint64_t        user_supervisor :1;
// 		uint64_t        write_through   :1;
// 		uint64_t        cache_disabled  :1;
// 		uint64_t        accessed        :1;
// 		uint64_t        reserved        :3;
// 		uint64_t        available       :3;
// 		uint64_t        base_addr       :32;
// 		uint64_t        reserved2       :8;
// 		uint64_t        available2      :11;
// 		uint64_t        execute_disable :1;
// 	} pdir;
// 	struct {
// 		uint64_t        present         :1;
// 		uint64_t        read_write      :1;
// 		uint64_t        user_supervisor :1;
// 		uint64_t        write_through   :1;
// 		uint64_t        cache_disabled  :1;
// 		uint64_t        accessed        :1;
// 		uint64_t        dirty           :1;
// 		uint64_t        always1         :1;
// 		uint64_t        global          :1;
// 		uint64_t        available       :3;
// 		uint64_t        attr_index      :1;
// 		uint64_t        reserved        :17;
// 		uint64_t        base_addr       :10;
// 		uint64_t        reserved2       :12;
// 		uint64_t        available2      :11;
// 		uint64_t        execute_disable :1;
// 	} huge;


// 	struct {
// 		uint64_t        present         :1;
// 		uint64_t        read_write      :1;
// 		uint64_t        user_supervisor :1;
// 		uint64_t        write_through   :1;
// 		uint64_t        cache_disabled  :1;
// 		uint64_t        accessed        :1;
// 		uint64_t        dirty           :1;
// 		uint64_t        always1         :1;
// 		uint64_t        global          :1;
// 		uint64_t        available       :3;
// 		uint64_t        attr_index      :1;
// 		uint64_t        reserved        :8;
// 		uint64_t        base_addr       :19;
// 		uint64_t        reserved2       :12;
// 		uint64_t        available2      :11;
// 		uint64_t        execute_disable :1;
// 	} large;
// 	struct {
// 		uint64_t        present         :1;
// 		uint64_t        read_write      :1;
// 		uint64_t        user_supervisor :1;
// 		uint64_t        write_through   :1;
// 		uint64_t        cache_disabled  :1;
// 		uint64_t        accessed        :1;
// 		uint64_t        dirty           :1;
// 		uint64_t        attr_index      :1;
// 		uint64_t        global          :1;
// 		uint64_t        available       :3;
// 		uint64_t        base_addr       :28;
// 		uint64_t        reserved2       :12;
// 		uint64_t        available2      :11;
// 		uint64_t        execute_disable :1;
// 	} base;
// };
/*
 * ============================================================================
 * arm64 Page-Table Layout
 * ============================================================================
 */
union ptable_entry {
	uint64_t raw;
	struct {
		uint64_t        present         :1;  //invalid 0 , valid 1
		uint64_t        table_entry     :1;  //table entry  1,  block entry  0
		uint64_t        attrindex       :3;  //bit[4:2]，Stage1 memory attributes index, for MAIR_ELx
		uint64_t        ns              :1;  //bit[5]，non-secure bit
		uint64_t        ap              :2;  //bit[7:6]，Data Access Permission
		uint64_t        sh              :2;  //bit[9:8]，Shareability field
		uint64_t        af              :1;  //AF，bit[10]，Access flag
		uint64_t        reserved        :1;
		uint64_t        base_addr       :36; // bit[47:12]
		uint64_t        reserved2       :11;  // bit[58:48]
		uint64_t        pxntable        :1;  // bit[59]
		uint64_t        xntable         :1;  // bit[60]
		uint64_t        aptable         :2;  // bit[62:61]
		uint64_t        nstable         :1;  // bit[63]
	} pdir;
	struct {
		uint64_t        present         :1;
		uint64_t        read_write      :1;
		uint64_t        user_supervisor :1;
		uint64_t        write_through   :1;
		uint64_t        cache_disabled  :1;
		uint64_t        accessed        :1;
		uint64_t        dirty           :1;
		uint64_t        always1         :1;
		uint64_t        global          :1;
		uint64_t        available       :3;
		uint64_t        attr_index      :1;
		uint64_t        reserved        :17;
		uint64_t        base_addr       :10;
		uint64_t        reserved2       :12;
		uint64_t        available2      :11;
		uint64_t        execute_disable :1;
	} huge;


	struct {
		uint64_t        present         :1;
		uint64_t        read_write      :1;
		uint64_t        user_supervisor :1;
		uint64_t        write_through   :1;
		uint64_t        cache_disabled  :1;
		uint64_t        accessed        :1;
		uint64_t        dirty           :1;
		uint64_t        always1         :1;
		uint64_t        global          :1;
		uint64_t        available       :3;
		uint64_t        attr_index      :1;
		uint64_t        reserved        :8;
		uint64_t        base_addr       :19;
		uint64_t        reserved2       :12;
		uint64_t        available2      :11;
		uint64_t        execute_disable :1;
	} large;
	struct {
		uint64_t        present         :1;
		uint64_t        read_write      :1;
		uint64_t        user_supervisor :1;
		uint64_t        write_through   :1;
		uint64_t        cache_disabled  :1;
		uint64_t        accessed        :1;
		uint64_t        dirty           :1;
		uint64_t        attr_index      :1;
		uint64_t        global          :1;
		uint64_t        available       :3;
		uint64_t        base_addr       :28;
		uint64_t        reserved2       :12;
		uint64_t        available2      :11;
		uint64_t        execute_disable :1;
	} base;
};

struct pdirbit{
		uint64_t        present         :1;  //invalid 0 , valid 1
		uint64_t        table_entry     :1;  //table entry  1,  block entry  0
		uint64_t        attrindex       :3;  //bit[4:2]，Stage1 memory attributes index, for MAIR_ELx
		uint64_t        ns              :1;  //bit[5]，non-secure bit
		uint64_t        ap              :2;  //bit[7:6]，Data Access Permission
		uint64_t        sh              :2;  //bit[9:8]，Shareability field
		uint64_t        af              :1;  //AF，bit[10]，Access flag
		uint64_t        reserved        :1;
		uint64_t        base_addr       :36; // bit[47:12]
		uint64_t        reserved2       :11;  // bit[58:48]
		uint64_t        pxntable        :1;  // bit[59]
		uint64_t        xntable         :1;  // bit[60]
		uint64_t        aptable         :2;  // bit[62:61]
		uint64_t        nstable         :1;  // bit[63]
};
/*
 * ============================================================================
 * Getting the KVM process id and ePT/sPT root
 * ============================================================================
 */
static int get_kvm_by_vpid(pid_t nr)
{
	// struct pid* pid;
	// struct task_struct* task;
	// struct files_struct* files;
	// int fd, max_fds;
	// rcu_read_lock();
	// if(!(pid = find_vpid(nr)))
	// {
	// 	rcu_read_unlock();
	// 	printk(KERN_DEBUG "[ptdump] no such process whose pid = %d\n", nr);
	// 	return -1;
	// }
	// if(!(task = pid_task(pid, PIDTYPE_PID)))
	// {
	// 	rcu_read_unlock();
	// 	printk(KERN_DEBUG "[ptdump] no such process whose pid = %d\n", nr);
	// 	return -1;
	// }
	// files = task->files;
	// max_fds = files_fdtable(files)->max_fds;
	// for(fd = 0; fd < max_fds; fd++)
	// {
	// 	struct file* file;
	// 	char buffer[32];
	// 	char* fname;
	// 	if(!(file = fcheck_files(files, fd)))
	// 		continue;
	// 	fname = d_path(&(file->f_path), buffer, sizeof(buffer));
	// 	if(fname < buffer || fname >= buffer + sizeof(buffer))
	// 		continue;
	// 	if(strcmp(fname, "anon_inode:kvm-vm") == 0)
	// 	{
	// 		kvm = file->private_data;
	// 		if (!kvm)
	// 			printk(KERN_DEBUG"[ptdump] KVM not found\n");
	// 		//kvm_get_kvm(kvm);
	// 		refcount_inc(&kvm->users_count);
	// 		break;
	// 	}
	// }
	// rcu_read_unlock();
	// if(!kvm) {
	// 	printk(KERN_DEBUG "[ptdump] process (pid = %d) has no kvm\n", nr);
	// 	return -1;
	// }
	return 0;
}

// #define virt_to_pfn(addr)	(__pa(addr) >> PAGE_SHIFT)
long get_vcpu_spt_reach(pgd_t *root)
{
	long count = 0;
	// unsigned long long addr;
	// union ptable_entry *l4, *l3, *l2, *l1;
	// int i, j, k, l;

	// l4 = phys_to_virt(virt_to_phys(root) & ~0xfff);
	// if (!pfn_valid(virt_to_pfn(l4)))
	// 	return -1;

	// for (i = 0; i < 512; i++) {
	// 	if (!l4[i].pdir.present)
	// 		continue;

	// 	addr = (unsigned long long)l4[i].pdir.base_addr << 12;
	// 	l3 = phys_to_virt(addr);
	// 	if (!pfn_valid(virt_to_pfn(l3)))
	// 		return -1;

	// 	for(j = 0; j < 512; j++) {
	// 		if (!l3[j].pdir.present)
	// 			continue;

	// 		addr = (unsigned long long)l3[j].pdir.base_addr << 12;
	// 		l2 = phys_to_virt(addr);
	// 		if (!pfn_valid(virt_to_pfn(l2)))
	// 			return -1;

	// 		for (k = 0; k < 512; k++) {
	// 			if (!l2[k].pdir.present)
	// 				continue;

	// 			addr = (unsigned long long)l2[k].pdir.base_addr << 12;
	// 			l1 = phys_to_virt(addr);
	// 			if (!pfn_valid(virt_to_pfn(l1)))
	// 				return -1;

	// 			for (l = 0; l < 512; l++) {
	// 				if (!l1[l].pdir.present)
	// 					continue;

	// 				count++;
	// 			}
	// 		}
	// 	}
	// }
	return count;
}

static int get_vcpu_shadow_root(uint64_t **rootp, int index)
{
	// uint64_t root = 0;
	// int vcpu_count;
	// struct kvm_vcpu *vcpu;

	// vcpu_count = atomic_read(&(kvm->online_vcpus));
	// if (index >= vcpu_count) {
	// 	printk(KERN_DEBUG"[ptdump] vcpu %d is greater than online vcpus %d\n", index, vcpu_count);
	// 	return -1;
	// }
	// vcpu = kvm_get_vcpu(kvm, index);
	// if (!vcpu) {
	// 	printk(KERN_DEBUG"[ptdump] vcpu %d is not initialized\n", index);
	// 	return -1;
	// }
	// root = KVM_VCPU_MMU_ROOT;
	// if (!root || !VALID_PAGE(root)) {
	// 	printk(KERN_DEBUG"[ptdump] Invalid root for vcpu: %d\n", index);
	// 	return -1;
	// }
	// printk(KERN_DEBUG"[ptdump] Initiating Shadow Page Table Dump for vcpu:%d\n", index);
	// (*rootp) = (uint64_t *)__va(root);
	return 0;
}

static int get_kvm_largest_shadow_root(uint64_t **rootp)
{
	// long nr_pages = -1, max_pages = -1;
	// int i, ret = -1, vcpu_count, best_vcpu = -1;
	// struct kvm_vcpu *vcpu;

	// vcpu_count = atomic_read(&(kvm->online_vcpus));
	// for (i = 0; i < vcpu_count; i++) {
	// 	break;
	// 	vcpu = kvm_get_vcpu(kvm, i);
	// 	if (!vcpu)
	// 		continue;

	// 	if (!KVM_VCPU_MMU_ROOT || !VALID_PAGE(KVM_VCPU_MMU_ROOT))
	// 		continue;

	// 	nr_pages = get_vcpu_spt_reach((pgd_t *)__va(KVM_VCPU_MMU_ROOT));
	// 	if (nr_pages > max_pages) {
	// 		max_pages = nr_pages;
	// 		best_vcpu = i;
	// 	}
	// }
	// best_vcpu = 0;
	// if (best_vcpu == -1) {
	// 	printk(KERN_INFO"[ptdump] Couldn't find a VCPU to dump ptables\n");
	// 	*rootp = NULL;
	// } else {
	// 	best_vcpu = 0;
	// 	printk(KERN_INFO"[ptdump] Dumping SPT with VCPU: %d\n", best_vcpu);
	// 	ret = get_vcpu_shadow_root(rootp, best_vcpu);
	// }
	// return ret;
	return 0;
}

static int get_ept_root(uint64_t** rootp)
{
	// uint64_t root = 0;
	// int i, vcpu_count = atomic_read(&(kvm->online_vcpus));
	// for(i = 0; i < vcpu_count; i++)
	// {
	// 	struct kvm_vcpu* vcpu = kvm_get_vcpu(kvm, i);
	// 	uint64_t root_of_vcpu;
	// 	if(!vcpu) {
	// 		printk(KERN_DEBUG "[ptdump] vcpu[%d] of pid: %d is uncreated\n",
	// 				i, kvm->userspace_pid);
	// 		continue;
	// 	}
	// 	if(!(root_of_vcpu = KVM_VCPU_MMU_ROOT)) {
	// 		printk(KERN_DEBUG "[ptdump] vcpu[%d] is uninitialized\n", i);
	// 		continue;
	// 	}
	// 	if(!root)
	// 		root = root_of_vcpu;
	// 	else if(root != root_of_vcpu)
	// 		printk(KERN_DEBUG "[ptdump] ept root of vcpu[%d] is %llx, different from other vcpus\n",
	// 				i, root_of_vcpu);
	// }
	// (*rootp) = root ? (uint64_t*)__va(root) : NULL;
	return 0;
}

/*
 * ============================================================================
 * Getting the task mm struct
 * ============================================================================
 */
static pgd_t *get_task_pgd(int pid, struct task_struct *task)
{
	int retval;

	/* select host or extended page tables */
	if (pgtables_type == PTDUMP_REGULAR) {
		mm = get_task_mm(task);
		if (!mm)
			return NULL;
		return mm->pgd;
	}
	/* enter into virtualization specific dumping */
	retval = get_kvm_by_vpid(pid);
	if (retval) {
		printk(KERN_DEBUG"[ptdump] Unable to find associated KVM for the given PID\n");
		return NULL;
	}
	if (pgtables_type == PTDUMP_ePT) {
		uint64_t *ept_root = NULL;
		printk(KERN_DEBUG"[ptdump] dumping KVM's ePT\n");
		/* get extended page table root pointer */
		retval = get_ept_root(&ept_root);
		if (retval)
			goto error;
		return (pgd_t *)ept_root;
	} else if (pgtables_type == PTDUMP_sPT) {
		uint64_t *shadow_root = NULL;
		printk(KERN_DEBUG"[ptdump] dumping KVM's shadow PT\n");
		/* get shadow page table root pointer*/
		if (shadow_root)
			return (pgd_t *)shadow_root;

		retval = get_kvm_largest_shadow_root(&shadow_root);
		if (retval)
			goto error;
		return (pgd_t *)shadow_root;
	}
error:
	printk(KERN_DEBUG"[ptdump] Unable to get to the root of KVM page table\n");
	return NULL;
}

static void put_task_pgd(void)
{
	if (pgtables_type == PTDUMP_REGULAR)
		mmput(mm);
	else if (pgtables_type == PTDUMP_ePT || pgtables_type == PTDUMP_sPT)
		//kvm_put_kvm(kvm);
		refcount_dec(&kvm->users_count);
	return;
}

/*
 * ============================================================================
 * NUMA Region Dumping
 * ============================================================================
 */
static long export_numa_map(void *user_buf, unsigned user_buf_bytes)
{
	unsigned long base, limit;
	struct pglist_data *node;
	int id, nr_visited = 0;
	void *curr;

	printk(KERN_DEBUG "[ptdump] Exporting numa map. #nodes: %d\n", nr_node_ids);
	if(!memory_user_accessible(user_buf, user_buf_bytes))
		return PTDUMP_ERR_ACCESS_RIGHTS;

	curr = user_buf + offsetof(struct nodemap, node);
	/* copy node range one-by-one and also keep track of the number of nodes visited */
	while (nr_visited < nr_node_ids) {
		node = NODE_DATA(nr_visited);
		id = node->node_id;
		base = page_to_phys(pfn_to_page(node->node_start_pfn));
		limit = page_to_phys(pfn_to_page(pgdat_end_pfn(node)));
		copy_to_user(curr + offsetof(struct numa_node_info, id), &id, sizeof(id));
		copy_to_user(curr + offsetof(struct numa_node_info, node_start_pfn), &base, sizeof(base));
		copy_to_user(curr + offsetof(struct numa_node_info, node_end_pfn), &limit, sizeof(limit));
		curr = curr + sizeof(struct numa_node_info);
		nr_visited += 1;
	}
	copy_to_user(user_buf, &nr_visited, sizeof(nr_visited));
	return 0;
}

typedef int (*ptdump_fn_t)( struct task_struct *task, pgd_t *start, unsigned ptstart, unsigned ptend, void *userbuf);

/*
 * ============================================================================
 * CRC-Calculation
 * ============================================================================
 */
static unsigned int crc32_for_byte(unsigned int r) 
{
	int j;
	for(j = 0; j < 8; ++j) {
		r = (r & 1? 0: (unsigned int)0xEDB88320L) ^ r >> 1;
	}
	return r ^ (unsigned int)0xFF000000L;
}

static void crc32(const void *data, unsigned long n_bytes, unsigned int* crc) 
{
	unsigned long i;
	static unsigned table[0x100];
	if(!*table) {
		for(i = 0; i < 0x100; ++i) {
			table[i] = crc32_for_byte(i);
		}
	}

	for(i = 0; i < n_bytes; ++i) {
		*crc = table[(unsigned char)*crc ^ ((unsigned char*)data)[i]] ^ *crc >> 8;
	}
}

/*
 * ============================================================================
 * Page-Table Dumping
 * ============================================================================
 */
static void ptdump_dump_table(void **userbuf, unsigned long *offset, unsigned long base, unsigned long va,
		unsigned level)
{
	static struct ptdump_table tmptable;
	void *vbase;

	if (*offset > PTDUMP_DUMP_SIZE_MAX) {
		printk("[ptdump] exceeded buffer limit");
		return;
	}

	vbase = phys_to_virt(base);

	tmptable.base = PTDUMP_TABLE_MKBASE(base, level);//记录物理地址 和 等级
	tmptable.vbase = va;
	memcpy(tmptable.entries, vbase, sizeof(tmptable.entries));//用虚拟地址把512个页表项取出

	copy_to_user(*userbuf, (void *)&tmptable, sizeof(tmptable));

	*userbuf = (char *)*userbuf + sizeof(tmptable);
	*offset = *offset + 1;
}

#define PTABLE_BASE_MASK(x)     (x&0xfffffffff000UL)
#define PT64_BASE_ADDR_MASK __sme_clr((((1ULL << 52) - 1) & ~(u64)(PAGE_SIZE-1)))
static int ptdump_dump(struct task_struct *task, pgd_t *start, unsigned ptstart, unsigned ptend, void *userbuf)
{
	unsigned l2, l3, l4;
	// union ptable_entry *pml4;
	// union ptable_entry *pdpt;
	// union ptable_entry *pdir;
	struct pdirbit *pml4;
	struct pdirbit *pdpt;
	struct pdirbit *pdir;
	unsigned long long addr;
	unsigned long offset;
	void *ptbuf;

	if (ptend >= 512) {
		ptend = 512;
	}
	offset = 0;
	ptbuf = ((char *)userbuf + offsetof(struct ptdump , table));

	printk(KERN_DEBUG "[ptdump] dump of pagetable %p from pml4[%d..%d]\n", start, ptstart, ptend);
	pml4 = phys_to_virt(virt_to_phys(start) & ~0xfff);

	ptdump_dump_table(&ptbuf, &offset, virt_to_phys(start) & ~0xfff, 0, 4);
	for (l4 = ptstart; l4 < ptend; l4++) {
		if (!pml4[l4].present)
			continue;

		addr = (unsigned long long)pml4[l4].base_addr << 12;//页表的物理地址，物理地址是为了传出去比对位于那个NUMA节点。
		pdpt = phys_to_virt(addr);//虚拟地址是为了查找下一级页表
		ptdump_dump_table(&ptbuf, &offset, addr, VA(l4, 0, 0, 0), 3);

		for (l3 = 0; l3 < 512; l3++) {
			if (!pdpt[l3].present) {
				continue;
			}
			// if (pdpt[l3].huge.always1) {
			// 	continue;
			// }

			addr = (unsigned long long)pdpt[l3].base_addr << 12;
			pdir = phys_to_virt(addr);
			ptdump_dump_table(&ptbuf, &offset, addr, VA(l4, l3, 0, 0), 2);

			for (l2 = 0; l2 < 512; l2++) {
				if (!pdir[l2].present)
					continue;

				// if (pdir[l2].large.always1)
				// 	continue;

				addr = (unsigned long long)pdir[l2].base_addr << 12;
				ptdump_dump_table(&ptbuf, &offset, addr, VA(l4, l3, l2, 0), 1);
			}
		}
	}
	printk(KERN_DEBUG "[ptdump] dumped %ld tables from\n", offset);

	ptbuf = ((char *)userbuf + offsetof(struct ptdump , num_tables));

	copy_to_user((void *)((char *)ptbuf), (void *)&offset, sizeof(offset));

	ptbuf = ((char *)userbuf + offsetof(struct ptdump , num_migrations));

	copy_to_user((void *)((char *)ptbuf), (void *)&task->numa_pages_migrated, sizeof(task->numa_pages_migrated));

	return 0;
}

static int ptdump_crc32(struct task_struct *task, pgd_t *start, unsigned ptstart, unsigned ptend, void *userbuf)
{
	// struct ptcrc32 crcs = PTCRC32_INIT;

	// unsigned l1, l2, l3, l4;
	// union ptable_entry *pml4;
	// union ptable_entry *pdpt;
	// union ptable_entry *pdir;
	// union ptable_entry *pte;
	// unsigned long long addr;

	// if (ptend >= 512) {
	// 	ptend = 512;
	// }

	// printk(KERN_DEBUG "[ptdump] crc of pagetable %p from pml4[%d..%d]\n", start, ptstart, ptend);

	// pml4 = phys_to_virt(virt_to_phys(start) & ~0xfff);

	// for (l4 = ptstart; l4 < ptend; l4++) {
	// 	crc32(&pml4[l4], 8, &crcs.pml4);
	// 	crc32(&pml4[l4], 8, &crcs.table);

	// 	if (!pml4[l4].pdir.present) {
	// 		continue;
	// 	}

	// 	addr = (unsigned long long)pml4[l4].pdir.base_addr << 12;
	// 	pdpt = phys_to_virt(addr);

	// 	for (l3 = 0; l3 < 512; l3++) {
	// 		crc32(&pdpt[l3], 8, &crcs.pdpt);

	// 		if (!pdpt[l3].pdir.present) {
	// 			crc32(&pdpt[l3], 8, &crcs.table);
	// 			continue;
	// 		}

	// 		if (pdpt[l3].huge.always1) {
	// 			/* huge page mapping */
	// 			crc32(&pdpt[l3], 8, &crcs.data);
	// 			continue;
	// 		}

	// 		crc32(&pdpt[l3], 8, &crcs.table);

	// 		addr = (unsigned long long)pdpt[l3].pdir.base_addr << 12;
	// 		pdir = phys_to_virt(addr);

	// 		for (l2 = 0; l2 < 512; l2++) {
	// 			crc32(&pdir[l2], 8, &crcs.pdir);

	// 			if (!pdir[l2].pdir.present) {
	// 				crc32(&pdir[l2], 8, &crcs.table);
	// 				continue;
	// 			}

	// 			if (pdir[l2].large.always1) {
	// 				/* large page */
	// 				crc32(&pdir[l2], 8, &crcs.data);
	// 				continue;
	// 			}

	// 			crc32(&pdir[l2], 8, &crcs.table);

	// 			addr = (unsigned long long)pdir[l2].pdir.base_addr << 12;
	// 			pte = phys_to_virt(addr);

	// 			for (l1 = 0; l1 < 512; l1++) {
	// 				crc32(&pte[l1], 8, &crcs.pt);
	// 				if (!pte[l1].base.present)
	// 					continue;

	// 				crc32(&pte[l1], 8, &crcs.data);
	// 			}
	// 		}
	// 	}
	// }


	// copy_to_user(userbuf, (void *)&crcs, sizeof(crcs));

	return 0;
}

static void update_range(unsigned long *base, unsigned long *limit, 
		unsigned long addr, unsigned long size)
{
	if (*base > addr) {
		*base = addr;
	}

	if (*limit < addr + size - 1) {
		*limit = addr + size - 1;
	}
}

#define update_data_range(range, addr, size) \
	(update_range(&range.data_base, &range.data_limit, addr, size))
#define update_pt_range(range, addr) \
	(update_range(&range.pt_base, &range.pt_limit, addr, 0x1000))
#define update_kernel_range(range, addr, size) \
	(update_range(&range.kernel_base, &range.kernel_limit, addr, size))
#define update_code_range(range, addr, size) \
	(update_range(&range.code_base, &range.code_limit, addr, size))

/*
 * ============================================================================
 * Page-Table Range Dumps
 * ============================================================================
 */
static int ptdump_range(struct task_struct *task, pgd_t *start, unsigned pml4_start, unsigned pml4_end,
		void *user_buf)
{
	// unsigned long long ptroot;
	// struct ptranges ranges = PTRANGES_INIT;

	// long unsigned l1, l2, l3, l4;

	// union ptable_entry *pml4;
	// union ptable_entry *pdpt;
	// union ptable_entry *pdir;
	// union ptable_entry *pte;
	// unsigned long long addr;

	// printk(KERN_DEBUG "[ptdump] ranges of pagetable %p from pml4[%d..%d]\n", start,
	// 		pml4_start, pml4_end);

	// ptroot = virt_to_phys(start) & ~0xfff;

	// ranges.pml4_base = ptroot;
	// ranges.pml4_limit = ranges.pml4_base + 0xfff;

	// pml4 = phys_to_virt(ptroot);


	// for (l4 = pml4_start; l4 < pml4_end; l4++) {
	// 	if (!pml4[l4].pdir.present)
	// 		continue;

	// 	addr = (unsigned long long)pml4[l4].pdir.base_addr << 12;
	// 	update_pt_range(ranges, addr);

	// 	pdpt = phys_to_virt(addr);

	// 	for (l3 = 0; l3 < 512; l3++) {
	// 		if (!pdpt[l3].pdir.present)
	// 			continue;

	// 		if (pdpt[l3].huge.always1) {
	// 			/* huge page mapping */
	// 			addr = (unsigned long long)pdpt[l3].huge.base_addr << 30;
	// 			if (pml4[l4].pdir.execute_disable || pdpt[l3].huge.execute_disable)
	// 				update_data_range(ranges, addr, HUGE_PAGE_SIZE);
	// 			else
	// 				update_code_range(ranges, addr, HUGE_PAGE_SIZE);

	// 			if (!(pml4[l4].pdir.user_supervisor && pdpt[l3].huge.user_supervisor))
	// 				update_kernel_range(ranges, addr, HUGE_PAGE_SIZE);

	// 			continue;
	// 		}

	// 		addr = (unsigned long long)pdpt[l3].pdir.base_addr << 12;
	// 		pdir = phys_to_virt(addr);
	// 		update_pt_range(ranges, addr);

	// 		for (l2 = 0; l2 < 512; l2++) {
	// 			if (!pdir[l2].pdir.present)
	// 				continue;

	// 			if (pdir[l2].large.always1) {
	// 				/* large page */
	// 				addr = (unsigned long long)pdir[l2].large.base_addr << 21;
	// 				if (pml4[l4].pdir.execute_disable
	// 						|| pdpt[l3].pdir.execute_disable
	// 						|| pdir[l2].large.execute_disable)
	// 					update_data_range(ranges, addr, LARGE_PAGE_SIZE);
	// 				else
	// 					update_code_range(ranges, addr, LARGE_PAGE_SIZE);

	// 				// if (!(pml4[l4].pdir.user_supervisor
	// 				// 			&& pdpt[l3].pdir.user_supervisor
	// 				// 			&& pdir[l2].large.user_supervisor))
	// 				// 	update_kernel_range(ranges, addr, LARGE_PAGE_SIZE);
	// 				continue;
	// 			}

	// 			addr = (unsigned long long)pdir[l2].pdir.base_addr << 12;
	// 			pte = phys_to_virt(addr);

	// 			update_pt_range(ranges, addr);

	// 			for (l1 = 0; l1 < 512; l1++) {
	// 				if (!pte[l1].base.present)
	// 					continue;

	// 				addr = (unsigned long long)pte[l1].base.base_addr << 12;
	// 				if (pml4[l4].pdir.execute_disable
	// 						|| pdpt[l3].pdir.execute_disable
	// 						|| pdir[l2].pdir.execute_disable
	// 						|| pte[l1].base.execute_disable)
	// 					update_data_range(ranges, addr, BASE_PAGE_SIZE);
	// 				else
	// 					update_code_range(ranges, addr, BASE_PAGE_SIZE);

	// 				// if (!(pml4[l4].pdir.user_supervisor
	// 				// 			&& pdpt[l3].pdir.user_supervisor
	// 				// 			&& pdir[l2].pdir.user_supervisor
	// 				// 			&& pte[l1].base.user_supervisor))
	// 				// 	update_kernel_range(ranges, addr, BASE_PAGE_SIZE);
	// 			}
	// 		}
	// 	}
	// }

	// copy_to_user(user_buf, (void *)&ranges, sizeof(ranges));

	return 0;
}

/*
 * ============================================================================
 * I/O CTL Handler Function
 * ============================================================================
 */
static long ptdump_ioctl(struct file *file, unsigned int cmd, unsigned long param)
{
	struct pid *pids;
	struct task_struct *task;
	pgd_t *pgd;
	void *user_buf;
	unsigned long user_buf_bytes;
	int retval;
	ptdump_fn_t handler;
	pid_t pid;
	unsigned slot_start, slot_end;

	user_buf = PTDUMP_IOCTL_EXBUF(param);

	switch(PTDUMP_IOCTL_EXCMD(cmd)) {
		case PTDUMP_IOCTL_CMD_DUMP :
			user_buf_bytes = sizeof(struct ptdump);
			handler = ptdump_dump;
			break;
		case PTDUMP_IOCTL_CMD_CRC32 :
			user_buf_bytes = sizeof(struct ptcrc32);
			handler = ptdump_crc32;
			break;
		case PTDUMP_IOCTL_CMD_RANGES :
			user_buf_bytes = sizeof(struct ptranges);
			handler = ptdump_range;
			break;
		case PTDUMP_IOCTL_NUMA_NODEMAP:
			user_buf_bytes = sizeof(struct nodemap);
			return export_numa_map(user_buf, user_buf_bytes);
		case PTDUMP_IOCTL_PGTABLES_TYPE:
			pgtables_type = param;
			return 0;
		default :
			return PTDUMP_ERR_CMD_INVALID;
	}

	if(!memory_user_accessible(user_buf, user_buf_bytes)) {
		return PTDUMP_ERR_ACCESS_RIGHTS;
	}

	copy_from_user(&pid, user_buf, sizeof(pid));

	if (pid == 0) {
		pid = task_pid_nr(current);
	}

	/* obtain the pid struct from the pid */
	pids = find_get_pid(pid);
	if (pids == NULL) {
		return PTDUMP_ERR_NO_SUCH_PROCESS;
	}

	task = pid_task(pids, PIDTYPE_PID);
	if (task == NULL) {
		return PTDUMP_ERR_NO_SUCH_TASK;
	}

	/* select either host, extended or shadow page tables*/
	pgd = get_task_pgd(pid, task);
	if (!pgd)
		return PTDUMP_ERR_NO_SUCH_TASK;

	//spin_lock_irqsave(&task->mm->page_table_lock, flags);
	#ifdef CONFIG_PAGE_TABLE_ISOLATION
	//    if (!static_cpu_has(X86_FEATURE_PTI)) {
	//        return 0;
	//    }
	printk(KERN_DEBUG "[ptdump] dumping arm64 page table of mm=%p with table isolation\n", task->mm);
	//pgd = kernel_to_user_pgdp(pgd);
	#else
	printk(KERN_DEBUG "[ptdump] dumping arm64 page table of mm=%p without table isolation\n", task->mm);
	#endif

	slot_start = PTDUMP_IOCTL_EXPTSTART(cmd);

	// if (slot_start > CONFIG_KERNEL_SPACE_START) {
	// 	slot_start = CONFIG_KERNEL_SPACE_START;
	// }

	slot_end = PTDUMP_IOCTL_EXPTEND(cmd);
	// if (slot_end > CONFIG_KERNEL_SPACE_START) {
	// 	slot_end = CONFIG_KERNEL_SPACE_START;
	// }

	retval = handler(task, pgd, slot_start, slot_end, user_buf);
	// spin_unlock_irqrestore(&task->mm->page_table_lock, flags);

	/* release the references */
	put_task_pgd();
	return retval;
}


struct proc_ops ptdump_ops = {
	.proc_ioctl = ptdump_ioctl,
	.proc_compat_ioctl   = ptdump_ioctl
};

static int __init page_table_dump_init(void) {

	printk(KERN_DEBUG "[ptdump] initializing module.\n");

	ptdump_proc = proc_create_data(CONFIG_PROCFS_FILE, 0644, NULL, &ptdump_ops, NULL);
	if (ptdump_proc == NULL) {
		remove_proc_entry(CONFIG_PROCFS_FILE, NULL);
		printk(KERN_ALERT "[ptdump] ERROR: could not initialize the procfs entry!\n");
		return -ENOMEM;
	}

	printk(KERN_DEBUG "[ptdump] file /proc/%s\n", CONFIG_PROCFS_FILE);
	printk(KERN_DEBUG "[ptdump] module initialzed.\n");

	return 0;
}

static void __exit page_table_dump_exit(void) {
	printk(KERN_DEBUG "[ptdump] removing module.\n");
	remove_proc_entry(CONFIG_PROCFS_FILE, NULL);
	printk(KERN_DEBUG "[ptdump] module removed.\n");
}

module_init(page_table_dump_init);
module_exit(page_table_dump_exit);
